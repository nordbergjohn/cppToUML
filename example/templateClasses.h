
template<typename T>
class TemplateClassT {
  TemplateClassT();
  ~TemplateClassT();
  /*
   int m_notIncluded; <- Part of multiline comment, not included in UML
   */
  private:
    T m_var;
};

// Template class with multiline inheritance
template<typename K, typename L, class M>
struct ChildT : public TemplateClassT<T>,
  protected Parent
{
  ChildT();
  //int dump(); <-  Not included in UML as this row is a comment
  protected:
    // Multiline function, should be included in UML
    const ExampleNameSpace::Type function(K k,
      L l,
      M m);
    K m_k;
    L m_l;
    const M m_m;
  private:
    template<class T, typename Args...>
      void fun(T& t, Args... args);
    ~ChildT();
    // Multiline variable, should be included in UML
    ExampleNameSpace::Type
      m_longVariableName;
};

